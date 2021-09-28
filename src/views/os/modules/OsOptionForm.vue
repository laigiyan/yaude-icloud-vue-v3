<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="實例名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="instanceName" >
              <a-input v-model="model.instanceName" placeholder="请输入實例名稱" :disabled="true"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="请输入描述"  :disabled="true"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" >
            <a-form-model-item label="鏡像" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="imgId">
              <a-select v-model="model.imgId"  placeholder="请选择鏡像" :disabled="true">
                <a-select-option v-for="imgs in imgIds":value="imgs.value">{{imgs.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="刪除實例時是否刪除卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="isDelete">
              <j-dict-select-tag type="radioButton" v-model="model.isDelete" dictCode="is_delete" placeholder="请选择刪除實例時是否刪除卷" :disabled="true"/>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="實例類型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="flavorId">
              <a-select v-model="model.flavorId"  placeholder="请选择實例類型" :disabled="true">
                <a-select-option v-for="flavors in flavorIds":value="flavors.value">{{flavors.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="安全組" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityName">
              <a-select v-model="model.securityName"  placeholder="请选择安全組" :disabled="true">
                <a-select-option v-for="securitys in securityNames":value="securitys.text">{{securitys.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="網絡" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkId">
              <a-select v-model="model.networkId"  placeholder="请选择網絡":disabled="true" >
                <a-select-option v-for="networks in networkIds":value="networks.value">{{networks.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
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
    name: 'OsOptionForm',
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
          optionsText: [
            { required: true, message: '请输入意见!'},
          ],
        },
        url: {
          add: "/os/osApply/add",
          edit: "/os/osApply/edit",
          queryById: "/os/osApply/queryById",
          readData: "/os/osApply/readData",
          agree: "/os/osOption/agree",
          refuse: "/os/osOption/refuse"
        },
        imgIds:[],
        flavorIds:[],
        securityNames:[],
        networkIds:[]

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
    },
    methods: {
      add () {
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
              that.close();
            })
          }

        })
      },
      agree(){
        const that = this;
        let method = "post";
        let httpurl = this.url.agree;
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
      },
      refuse(){
        debugger
        const that = this;
        let aa = this.model;
        let method = "post";
        let httpurl = this.url.refuse;
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

      },
      getImgs(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getImg;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            debugger
            const result = res.result
            result.forEach((r)=>{
              this.imgIds.push({
                value:r.imgId,
                text:r.imgName
              })
            })
          }
        })
      },
      getFlavorIds(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getFlavor;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            debugger
            const result = res.result
            result.forEach((r)=>{
              this.flavorIds.push({
                value:r.flavorId,
                text:r.flavorName
              })
            })
          }
        })
      },
      getSecurityNames(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getSecurity;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            debugger
            const result = res.result
            result.forEach((r)=>{
              this.securityNames.push({
                value:r.value,
                text:r.securityName
              })
            })
          }
        })
      },
      getNetworkIds(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.networkIds.push({

                value:r.networkId,
                text:r.networkName
              })
            })
          }
        })
      },



    }
  }
</script>