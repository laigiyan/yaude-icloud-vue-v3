<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="實例名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="instanceName">
              <a-input v-model="model.instanceName" placeholder="请输入實例名稱"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="请输入描述"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="鏡像id" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="imgId">
              <j-dict-select-tag type="list" v-model="model.imgId" dictCode="" placeholder="请选择鏡像id" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="刪除實例時是否刪除卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="isDelete">
              <j-dict-select-tag type="radioButton" v-model="model.isDelete" dictCode="is_delete" placeholder="请选择刪除實例時是否刪除卷" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="實例類型id" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="flavorId">
              <j-dict-select-tag type="list" v-model="model.flavorId" dictCode="" placeholder="请选择實例類型id" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="安全組" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityName">
              <j-dict-select-tag type="list" v-model="model.securityName" dictCode="" placeholder="请选择安全組" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="網絡" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkId">
              <j-dict-select-tag type="list" v-model="model.networkId" dictCode="" placeholder="请选择網絡" />
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
    name: 'OsApplyForm',
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
           instanceName: [
              { required: true, message: '请输入實例名稱!'},
           ],
           imgId: [
              { required: true, message: '请输入鏡像id!'},
           ],
           flavorId: [
              { required: true, message: '请输入實例類型id!'},
           ],
        },
        url: {
          add: "/os/osApply/add",
          edit: "/os/osApply/edit",
          queryById: "/os/osApply/queryById",
          rdadData: "/os/osApply/rdadData"
        }
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //备份model原始值
      this.getdata();
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
    },
    methods: {
      add () {
        debugger
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
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
      getdata(){
        const that = this;
        httpAction(this.url.rdadData,this.model,"put").then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
    }
  }
</script>