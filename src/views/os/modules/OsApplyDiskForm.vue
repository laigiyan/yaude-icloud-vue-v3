<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="diskName">
              <a-input v-model="model.diskName" placeholder="请输入名称" :disabled="editable" ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="请输入描述"  :disabled="editable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="大小" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="size">
              <a-input v-model="model.size" placeholder="请输入大小"  :disabled="justable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="类型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="type">
             <!-- <a-input v-model="model.type" placeholder="请输入类型"  ></a-input>-->
              <a-select v-model="model.type"  placeholder="请选择类型" :disabled="justable">
                <a-select-option v-for="type in types":value="type.value" >{{type.text}}</a-select-option>
              </a-select>

            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="来源" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="source">
              <j-dict-select-tag type="list" v-model="model.source" dictCode="disk_source" placeholder="请选择来源"  :disabled="justable"/>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="是否加密" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="bootable">
              <j-dict-select-tag type="list" v-model="model.bootable" dictCode="bootable" placeholder="请选择是否加密" :disabled="justable"/>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showoption">
            <a-form-model-item label="审核意见" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsText" >
              <a-textarea v-model="model.optionsText" placeholder="请输入审核意见" ></a-textarea>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'

  export default {
    name: 'OsApplyDiskForm',
    components: {
    },
    props: {
      //表单禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
         },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {
          diskName: [
            { required: true, message: '请输入名称!'},
          ],
          size: [
            { required: true, message: '请规定大小!'},
          ],
          type: [
            { required: true, message: '请选择类型!'},
          ],

        },
        url: {
          add: "/os/osApplyDisk/add",
          edit: "/os/osApplyDisk/edit",
          queryById: "/os/osApplyDisk/queryById",
          getType: "/os/osApplyDisk/getType",
          agree: "/os/osOption/agree",
          refuse: "/os/osOption/refuse"
        },
        types:[],
        editable: false,
        justable: false,
        showoption: false
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //备份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
      this.getType(this.modelDefault);
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        this.showoption = this.model.showoption;
        if(this.model.options=="1" || (this.model.options=="2" && this.model.status!=null) ){
          this.editable=true
          this.justable=true
        }else if(this.model.options=="2" && this.model.status==null){
          this.editable=true
          this.justable=false
        }
      },
      submitForm () {
        const that = this;
        // 触发表单验证
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
      //同意
      agree(){
        const that = this;
        let method = "post";
        this.model.applyType = "3";
        let httpurl = this.url.agree;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      //拒绝
      refuse(){
        const that = this;
        this.model.applyType = "3";
        let method = "post";
        let httpurl = this.url.refuse;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      getType(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getType;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.types.push({
                value:r.type,
                text:r.type
              })
            })
          }
        })
      }
    }
  }
</script>