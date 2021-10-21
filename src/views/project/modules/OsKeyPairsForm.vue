<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <!--<a-col :span="24">
            <a-form-model-item label="用户名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="userId">
              <a-select v-model="model.userId" @change="getAll" placeholder="请选择用户" >
                <a-select-option v-for="user in users":value="user.value"  >{{user.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>-->
          <a-col :span="24" >
            <a-form-model-item label="項目名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectId">
              <a-select v-model="model.projectId"  @change="getAll" placeholder="请选择項目" >
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="秘钥名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="keyName">
              <a-input v-model="model.keyName" placeholder="请输入秘钥名称"  :disabled="editKey"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showKey">
            <a-form-model-item label="指纹" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="fingerprint">
              <a-textarea v-model="model.fingerprint" placeholder="请输入指纹" :disabled="editKey"></a-textarea>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showKey">
            <a-form-model-item label="公钥" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="publicKey">
              <a-textarea v-model="model.publicKey" placeholder="请输入公钥" :disabled="editKey"></a-textarea>
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
    name: 'OsKeyPairsForm',
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
        },
        users:[],
        projects:[],
        showKey:false,
        editKey:false,
        url: {
          add: "/openstack/osKeyPairs/add",
          edit: "/openstack/osKeyPairs/edit",
          queryById: "/openstack/osKeyPairs/queryById",
          getProject: "/openstack/osKeyPairs/getProject",
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
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
    this.getProjects();
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        if(this.model.id){
          this.showKey=true;
          this.editKey=true;
        }
      },
      submitForm () {
        const that = this;
        this.projects.forEach((r)=>{
          if(r.value==that.model.projectId){
            that.model.projectName = r.text;
          }
        })
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
    /*  getAll(){
        this.getProjects();
      },
      getUser(){
        let method = "post";
        let httpurl = this.url.getUser;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            debugger
            result.forEach((r)=>{
              this.users.push({
                value:r.userId,
                text:r.userName,
              })
            })
          }
        })
      },*/
      getProjects(){
        let method = "post";
        let httpurl = this.url.getProject;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },

    }
  }
</script>